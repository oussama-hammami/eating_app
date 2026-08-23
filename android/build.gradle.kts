allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Plugin subprojects (e.g. file_picker's flutter_plugin_android_lifecycle
// dependency) generate their own Gradle module pinned to this Flutter SDK's
// default compileSdk (34), which is now older than what that dependency
// requires (36+). Force every Android library subproject to compile against
// 36 so `:file_picker:checkDebugAarMetadata` stops failing.
fun Project.forceCompileSdk36() {
    extensions.findByName("android")?.let { androidExt ->
        (androidExt as? com.android.build.gradle.BaseExtension)?.compileSdkVersion(36)
    }
}

subprojects {
    project.evaluationDependsOn(":app")
    if (state.executed) forceCompileSdk36() else afterEvaluate { forceCompileSdk36() }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
