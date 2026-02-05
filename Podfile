platform :ios, '26.0'
use_frameworks!

target 'Daily AI Affirmations' do
  pod 'Google-Mobile-Ads-SDK'

  target 'Daily AI AffirmationsTests' do
    inherit! :search_paths
  end

  target 'Daily AI AffirmationsUITests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  # Xcode 26: disable user script sandboxing to allow CocoaPods scripts to write temp files.
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
    end
  end

  installer.aggregate_targets.each do |aggregate|
    aggregate.user_project.native_targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      end
    end
  end

  # macOS realpath doesn't support -m; patch scripts to use -q only.
  Dir.glob(File.join(installer.sandbox.root, 'Target Support Files', '**', '*-resources.sh')).each do |path|
    contents = File.read(path)
    next unless contents.include?('realpath -mq')
    File.write(path, contents.gsub('realpath -mq', 'realpath -q'))
  end
end
