Pod::Spec.new do |s|
  s.name         = 'MHStackManager'
  s.version      = '1.0.0'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/mariohahn/StackManager'
  s.author = {
    'Mario Hahn' => 'mario_hahn@me.com'
  }
  s.summary      = 'StackManager'
  s.platform     =  :ios
  s.source = {
    :git => 'https://github.com/mariohahn/StackManager.git',
    :tag => 'v1.0.0'
  }

  s.dependency "Masonry"

  s.source_files = ['StackManager/StackManager/StackManager/**/*.{h,m}']
  s.ios.deployment_target = '7.0'
  s.requires_arc = true
end