
# Remove crypto-android-release.aar and pom.xml from the root directory if they exist
rm -f crypto-android-release.aar
rm -f pom.xml

# Get version name from gradle.properties
version_name=$(grep '^VERSION_NAME=' gradle.properties | cut -d'=' -f2)

echo "Current version name: $version_name"

# Change version in build.gradle
awk -v version="$version_name" '/^[[:space:]]*version =/ {gsub(/version = "[^"]+"/, "version = \"" version "\"")} 1' crypto-android/build.gradle > tmp && mv tmp crypto-android/build.gradle

# Change version in jitpack.yml
awk -v version="$version_name" '/-Dversion=/ {gsub(/-Dversion=[^ ]+/, "-Dversion=" version)} 1' jitpack.yml > tmp && mv tmp jitpack.yml

# Build the project
./gradlew clean
./gradlew assembleRelease

# Generate POM file for release publication
./gradlew :crypto-android:generatePomFileForReleasePublication

# Move matrix-sdk-android-release.aar to the root directory
mv crypto-android/build/outputs/aar/crypto-android-release.aar crypto-android-release.aar

# Move pom-default.xml to the root directory and rename it to pom.xml
mv crypto-android/build/publications/release/pom-default.xml pom.xml

# Remove <packaging>aar</packaging> from pom.xml
awk '!/<packaging>aar<\/packaging>/' pom.xml > tmp && mv tmp pom.xml

