require 'xcodeproj'

def install_awesome_fcm_ios_pod_target(application_path = nil)
    # defined_in_file is set by CocoaPods and is a Pathname to the Podfile.
    application_path ||= File.dirname(defined_in_file.realpath) if self.respond_to?(:defined_in_file)
    raise 'Could not find application path in install_awesome_fcm_ios_pod_target' unless application_path

    flutter_install_ios_engine_pod application_path
    pod 'awesome_notifications', :path => File.join('.symlinks', 'plugins', 'awesome_notifications', 'ios')
    pod 'awesome_notifications_fcm', :path => File.join('.symlinks', 'plugins', 'awesome_notifications_fcm', 'ios')
end

def update_awesome_fcm_service_target(target_name, xcodeproj_path, flutter_root)
     project = Xcodeproj::Project.open(File.join(xcodeproj_path, 'Runner.xcodeproj'))

     project.targets.each do |target|
         target.build_configurations.each do |config|
             config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'NO'
         end
     end
     
     target = project.targets.select { |t| t.name == target_name }.first
     if target.nil? || project.targets.count == 1
         raise "To fully utilize the awesome_notifications_fcm package, it's " +
             "essential to create a Notification Service Extension. This extension " +
             "is necessary for handling advanced notification features and ensuring " +
             "optimal functionality. Please refer to the awesome_notifications_fcm " +
             "documentation for detailed instructions on setting up the " +
             "Notification Service Extension\n"
     end

     target.build_configurations.each do |config|
         config.build_settings['ENABLE_BITCODE'] = 'NO'
         config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
         config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'NO'
         config.build_settings['OTHER_SWIFT_FLAGS'] = '-D TARGET_EXTENSION'
     end
     puts "[Awesome Notifications] Successfully updated build settings for the target: '#{target.name}'"
     
     project.save
end
