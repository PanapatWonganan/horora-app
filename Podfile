target 'Runner' do
  use_frameworks!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # ใช้ framework ที่มีอยู่แล้วแทน
  pod 'app_links', :path => 'Frameworks/app_links.framework'
  
  target 'RunnerTests' do
    inherit! :search_paths
  end
end 