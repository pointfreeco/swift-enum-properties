class GenerateEnumProperties < Formula
  desc "Generate properties for your enums"
  homepage "https://github.com/pointfreeco/swift-generate-enum-properties"
  curl "https://github.com/pointfreeco/swift-generate-enum-properties/archive/0.1.0.tar.gz"

  depends_on :xcode => ["10.2", :build]

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end
end
