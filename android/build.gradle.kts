// Top-level build.gradle.kts for Flutter with Gradle 8.13 + Kotlin 1.8.22

import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

// =====================================
// Buildscript: Android & Kotlin plugins
// =====================================
buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Android Gradle Plugin compatible with Gradle 8.13
        classpath("com.android.tools.build:gradle:8.1.0")
        // Kotlin plugin 1.8.22
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.22")
    }
}

// =====================================
// All projects repositories
// =====================================
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// =====================================
// Move build directories outside project
// =====================================
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Ensure app is evaluated first
subprojects {
    project.evaluationDependsOn(":app")
}

// =====================================
// Custom clean task
// =====================================
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}