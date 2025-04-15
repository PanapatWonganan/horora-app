require 'xcodeproj'

# Open the Xcode project
project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Create a new run script build phase
run_script = target.new_shell_script_build_phase('Add Privacy Manifests')
run_script.shell_script = '${FLUTTER_ROOT}/../.pub-cache/hosted/pub.dev/share_plus-7.2.2/ios/Classes/add_privacy_manifest.sh'

# Save the project
project.save 