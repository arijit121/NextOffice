import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.nextoffice.app"
            resValue(type = "string", name = "app_name", value = "NextOffice")
        }
        create("stg") {
            dimension = "flavor-type"
            applicationId = "com.nextoffice.app.stg"
            resValue(type = "string", name = "app_name", value = "Stg NextOffice")
        }
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.nextoffice.app.dev"
            resValue(type = "string", name = "app_name", value = "Dev NextOffice")
        }
    }
}