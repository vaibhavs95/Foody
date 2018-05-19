# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'

target 'Foody' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Foody
  pod 'Kingfisher', '~> 3.0'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == "Kingfisher"
            puts target
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
    end
end

end
