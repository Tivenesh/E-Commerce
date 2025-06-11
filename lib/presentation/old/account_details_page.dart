import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser!;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _username = TextEditingController();
  final _address = TextEditingController();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();

  File? _profileImage;
  String? _profileImageUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data != null) {
      _username.text = data['username'] ?? '';
      _address.text = data['address'] ?? '';
      setState(() {
        _profileImageUrl = data['profilePic'];
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  Future<String?> _uploadImage(File image) async {
    final ref = FirebaseStorage.instance.ref('profile_pics/${user.uid}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _updateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 🔐 Reauthenticate for password change
      if (_newPassword.text.isNotEmpty && _currentPassword.text.isNotEmpty) {
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPassword.text,
        );
        await _auth.currentUser!.reauthenticateWithCredential(cred);
        await _auth.currentUser!.updatePassword(_newPassword.text);
      }

      // 📷 Upload profile picture if selected
      String? uploadedImage;
      if (_profileImage != null) {
        uploadedImage = await _uploadImage(_profileImage!);
      }

      // 📝 Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'username': _username.text.trim(),
        'address': _address.text.trim(),
        if (uploadedImage != null) 'profilePic': uploadedImage,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profile updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: ${e.toString()}")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Account Details")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage:
                        _profileImage != null
                            ? FileImage(_profileImage!)
                            : (_profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    : null)
                                as ImageProvider?,
                    child:
                        _profileImage == null && _profileImageUrl == null
                            ? const Icon(Icons.camera_alt, size: 36)
                            : null,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _username,
                  decoration: InputDecoration(
                    labelText: "Username",
                    border: inputBorder,
                  ),
                  validator:
                      (val) => val == null || val.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  initialValue: user.email,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _address,
                  decoration: InputDecoration(
                    labelText: "Address",
                    border: inputBorder,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _currentPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Current Password",
                    border: inputBorder,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    border: inputBorder,
                  ),
                  validator: (val) {
                    if (val != null && val.isNotEmpty && val.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _updateAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _loading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text("Save Changes"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
