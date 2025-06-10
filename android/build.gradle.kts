import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

// ✅ Required for Flutter and Firebase setup
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Reposition build output (Flutter-specific)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// ✅ Custom clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}


// ✅ Apply Google Services plugin globally (needed for Firebase)
plugins {
   
    id("com.google.gms.google-services") version "4.3.15" apply false
}
