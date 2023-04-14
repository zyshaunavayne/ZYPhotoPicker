

Pod::Spec.new do |spec|

  spec.name         = "ZYPhotoPicker"
  spec.version      = "1.0.0"
  spec.summary      = "ZYPhotoPicker request of zhangyushaunavayne"
  spec.homepage     = "https://github.com/zyshaunavayne/ZYPhotoPicker"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "zyshaunavayne" => "shaunavayne@vip.qq.com" }
  spec.source = { git: "https://github.com/zyshaunavayne/ZYPhotoPicker.git", tag: "v#{spec.version}", submodules: true }
  spec.platform      = :ios,"11.0"
  spec.dependency    "HXPhotoPicker"
  spec.dependency    "TZImagePickerController"
  spec.dependency    "MJExtension"
  spec.frameworks   = "Foundation","UIKit","CoreServices"
  spec.source_files  = "ZYPhotoPicker/*.{h,m}"

end
