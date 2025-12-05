// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "MPVKit",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13)],
    products: [
        .library(
            name: "MPVKit",
            targets: ["_MPVKit"]
        ),
        .library(
            name: "MPVKit-GPL",
            targets: ["_MPVKit-GPL"]
        ),
    ],
    targets: [
        .target(
            name: "_MPVKit",
            dependencies: [
                "Libmpv", "_FFmpeg", "Libuchardet", "Libbluray",
            ],
            path: "Sources/_MPVKit",
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreAudio"),
            ]
        ),
        .target(
            name: "_FFmpeg",
            dependencies: [
                "Libavcodec", "Libavdevice", "Libavfilter", "Libavformat", "Libavutil", "Libswresample", "Libswscale",
                "Libssl", "Libcrypto", "Libass", "Libfreetype", "Libfribidi", "Libharfbuzz",
                "MoltenVK", "Libshaderc_combined", "lcms2", "Libplacebo", "Libdovi", "Libunibreak",
                "gmp", "nettle", "hogweed", "gnutls", "Libdav1d", "Libuavs3d"
            ],
            path: "Sources/_FFmpeg",
            linkerSettings: [
                .linkedFramework("AudioToolbox"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("Metal"),
                .linkedFramework("VideoToolbox"),
                .linkedLibrary("bz2"),
                .linkedLibrary("iconv"),
                .linkedLibrary("expat"),
                .linkedLibrary("resolv"),
                .linkedLibrary("xml2"),
                .linkedLibrary("z"),
                .linkedLibrary("c++"),
            ]
        ),
        .target(
            name: "_MPVKit-GPL",
            dependencies: [
                "Libmpv-GPL", "_FFmpeg-GPL", "Libuchardet", "Libbluray",
            ],
            path: "Sources/_MPVKit-GPL",
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreAudio"),
            ]
        ),
        .target(
            name: "_FFmpeg-GPL",
            dependencies: [
                "Libavcodec-GPL", "Libavdevice-GPL", "Libavfilter-GPL", "Libavformat-GPL", "Libavutil-GPL", "Libswresample-GPL", "Libswscale-GPL",
                "Libssl", "Libcrypto", "Libass", "Libfreetype", "Libfribidi", "Libharfbuzz",
                "MoltenVK", "Libshaderc_combined", "lcms2", "Libplacebo", "Libdovi", "Libunibreak",
                "Libsmbclient", "gmp", "nettle", "hogweed", "gnutls", "Libdav1d", "Libuavs3d"
            ],
            path: "Sources/_FFmpeg-GPL",
            linkerSettings: [
                .linkedFramework("AudioToolbox"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("Metal"),
                .linkedFramework("VideoToolbox"),
                .linkedLibrary("bz2"),
                .linkedLibrary("iconv"),
                .linkedLibrary("expat"),
                .linkedLibrary("resolv"),
                .linkedLibrary("xml2"),
                .linkedLibrary("z"),
                .linkedLibrary("c++"),
            ]
        ),

        .binaryTarget(
            name: "Libmpv-GPL",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-no-lua/Libmpv-GPL.xcframework.zip",
            checksum: "8dcb7d5ceff460429719ccdf25b84e932e4828c1017ab047cd993a7b75a38994"
        ),
        .binaryTarget(
            name: "Libavcodec-GPL",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-no-lua/Libavcodec-GPL.xcframework.zip",
            checksum: "6f949235a859573ee277fe58c08bf532d48cd22bdccd8ecee4de7e4ec1dfaf52"
        ),
        .binaryTarget(
            name: "Libavdevice-GPL",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-no-lua/Libavdevice-GPL.xcframework.zip",
            checksum: "7febfb16ad0e018bd19b67431314bde466921e190fa01ff80930e05149e50303"
        ),
        .binaryTarget(
            name: "Libavformat-GPL",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-no-lua/Libavformat-GPL.xcframework.zip",
            checksum: "41f7926527f66f756ecd2d3ff7e3fee4e2caa25695dd5cb64c26b09fe3d868cc"
        ),
        .binaryTarget(
            name: "Libavfilter-GPL",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-no-lua/Libavfilter-GPL.xcframework.zip",
            checksum: "8bc36559fb5c562bf1eabcc2d7fa433c4e6dcf7ebd3bdc9f1f2658e699e272c8"
        ),
        .binaryTarget(
            name: "Libavutil-GPL",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-no-lua/Libavutil-GPL.xcframework.zip",
            checksum: "0f7f4b7fd0c88276e3c3e55022258fdad0b107a21a5782f1fd6a7f873d4fd71a"
        ),
        .binaryTarget(
            name: "Libswresample-GPL",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-no-lua/Libswresample-GPL.xcframework.zip",
            checksum: "99805d8fccf9e81ee4420332f899e86ed16b5d5c2ab6b3291c8c98c89a47d9c2"
        ),
        .binaryTarget(
            name: "Libswscale-GPL",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-no-lua/Libswscale-GPL.xcframework.zip",
            checksum: "98363d41f28fab637bf010f5e3a10ee8c98ca4954ca241c1e711977b055568d7"
        ),
        //AUTO_GENERATE_TARGETS_BEGIN//

        .binaryTarget(
            name: "Libcrypto",
            url: "https://github.com/mpvkit/openssl-build/releases/download/3.3.2-xcode/Libcrypto.xcframework.zip",
            checksum: "2ee7fc0fa9c7c7fbdfcad0803d34ea3143456943681fdab6cf8cf094f4253053"
        ),
        .binaryTarget(
            name: "Libssl",
            url: "https://github.com/mpvkit/openssl-build/releases/download/3.3.2-xcode/Libssl.xcframework.zip",
            checksum: "cc57f4dd19659ddeaff1ff440764d0b439a6a93c8c4617241ba1243aa9fe5ad7"
        ),

        .binaryTarget(
            name: "gmp",
            url: "https://github.com/mpvkit/gnutls-build/releases/download/3.8.8-xcode/gmp.xcframework.zip",
            checksum: "019faab8625fedb38bb934fafb73a547c9cb29ccdeabfd3998256d1ea0760e2c"
        ),

        .binaryTarget(
            name: "nettle",
            url: "https://github.com/mpvkit/gnutls-build/releases/download/3.8.8-xcode/nettle.xcframework.zip",
            checksum: "bd4dbeea46a9abc02797c2f503d79636ee09b8a5f8ed4d2bbe2cc00e29c066cb"
        ),
        .binaryTarget(
            name: "hogweed",
            url: "https://github.com/mpvkit/gnutls-build/releases/download/3.8.8-xcode/hogweed.xcframework.zip",
            checksum: "48c300eadfbe61ab08b56a08fc5b979c84839c8bba665caf6515079949db0cbf"
        ),

        .binaryTarget(
            name: "gnutls",
            url: "https://github.com/mpvkit/gnutls-build/releases/download/3.8.8-xcode/gnutls.xcframework.zip",
            checksum: "8be5568b3bcaa7378e470b6eb2b11f1af86b5d5637229d1d3eb725a2e0c4b9da"
        ),

        .binaryTarget(
            name: "Libunibreak",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.4/Libunibreak.xcframework.zip",
            checksum: "001087c0e927ae00f604422b539898b81eb77230ea7700597b70393cd51e946c"
        ),

        .binaryTarget(
            name: "Libfreetype",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.4/Libfreetype.xcframework.zip",
            checksum: "f2840aba1ce35e51c0595557eee82c908dac8e32108ecc0661301c06061e051c"
        ),

        .binaryTarget(
            name: "Libfribidi",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.4/Libfribidi.xcframework.zip",
            checksum: "4a55513792ef7a17893875f74cc84c56f3657e8768c07a7a96f563a11dc4b743"
        ),

        .binaryTarget(
            name: "Libharfbuzz",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.4/Libharfbuzz.xcframework.zip",
            checksum: "91558d8497d9d97bc11eeef8b744d104315893bfee8f17483d8002e14565f84b"
        ),

        .binaryTarget(
            name: "Libass",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.4/Libass.xcframework.zip",
            checksum: "1e41f5a69c74f6c6407aab84a65ccd0b34e73fa44465f488f99bf22bd61b070d"
        ),

        .binaryTarget(
            name: "Libsmbclient",
            url: "https://github.com/mpvkit/libsmbclient-build/releases/download/4.15.13-xcode/Libsmbclient.xcframework.zip",
            checksum: "eca7ec0f3a226441c051773e2742670c85a2de522957b3580d3ccd65071281e5"
        ),

        .binaryTarget(
            name: "Libbluray",
            url: "https://github.com/mpvkit/libbluray-build/releases/download/1.3.4-xcode/Libbluray.xcframework.zip",
            checksum: "24d313a3a8808b95bd9bda7338ff9ec2141748cc172920b7733a435b2f39a690"
        ),

        .binaryTarget(
            name: "Libuavs3d",
            url: "https://github.com/mpvkit/libuavs3d-build/releases/download/1.2.1-xcode/Libuavs3d.xcframework.zip",
            checksum: "1e69250279be9334cd2f6849abdc884c8e4bb29212467b6f071fdc1ac2010b6b"
        ),

        .binaryTarget(
            name: "Libdovi",
            url: "https://github.com/mpvkit/libdovi-build/releases/download/3.3.1-xcode/Libdovi.xcframework.zip",
            checksum: "20021f2644da6986ae4ee456d8f917774f7c1324532843ff795ac3034ee7c88e"
        ),

        .binaryTarget(
            name: "MoltenVK",
            url: "https://github.com/mpvkit/moltenvk-build/releases/download/1.4.0-xcode/MoltenVK.xcframework.zip",
            checksum: "37cfd1af378058883f5c961966477cd6accf9923f0e48e0dfa2cf42a95b797fc"
        ),

        .binaryTarget(
            name: "Libshaderc_combined",
            url: "https://github.com/mpvkit/libshaderc-build/releases/download/2025.4.0-xcode/Libshaderc_combined.xcframework.zip",
            checksum: "dad5fe829dde498f41680f37adebac993fd7c04751042be2d79895eea5b24fb5"
        ),

        .binaryTarget(
            name: "lcms2",
            url: "https://github.com/mpvkit/lcms2-build/releases/download/2.16.0-xcode/lcms2.xcframework.zip",
            checksum: "9a08673dce386b0f75f6505ccb58df1f17421bffe035a6aebd4ab532fdc77274"
        ),

        .binaryTarget(
            name: "Libplacebo",
            url: "https://github.com/mpvkit/libplacebo-build/releases/download/7.351.0-xcode/Libplacebo.xcframework.zip",
            checksum: "75ec29cf670b4319509065f6c3b6acd99a220be372ac849b428e8bcba377b3f5"
        ),

        .binaryTarget(
            name: "Libdav1d",
            url: "https://github.com/mpvkit/libdav1d-build/releases/download/1.5.2-xcode/Libdav1d.xcframework.zip",
            checksum: "8a8b78e23e28ecc213232805f3c1936141fc9befe113e87234f4f897f430a532"
        ),

        .binaryTarget(
            name: "Libavcodec",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-no-lua/Libavcodec.xcframework.zip",
            checksum: "14dfc2aa693f02917e790250573bf33f3a56fd116ddc7de572dfd0caee51af91"
        ),
        .binaryTarget(
            name: "Libavdevice",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-no-lua/Libavdevice.xcframework.zip",
            checksum: "10098b2c7e1b346d488e42c60119566900648f23f09ee7c74133e34e47450615"
        ),
        .binaryTarget(
            name: "Libavformat",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-no-lua/Libavformat.xcframework.zip",
            checksum: "b6cad33cdf7e372b04f9ac13ec1058d18805c0d51ba94631c1003cb202148271"
        ),
        .binaryTarget(
            name: "Libavfilter",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-no-lua/Libavfilter.xcframework.zip",
            checksum: "3b2be753ceac51c80e8803701a4fa9fb8a60e14cb4d95ad989cdf68c1af3a5cb"
        ),
        .binaryTarget(
            name: "Libavutil",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-no-lua/Libavutil.xcframework.zip",
            checksum: "99a45834d0355741f18b5f9c706450abca7484d61763f7520131ac5e604a639e"
        ),
        .binaryTarget(
            name: "Libswresample",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-no-lua/Libswresample.xcframework.zip",
            checksum: "cfafe5e9e1d3e1d3b029c83a5435f9abe6d46dfb367ae5c42ca2b57846593c56"
        ),
        .binaryTarget(
            name: "Libswscale",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-no-lua/Libswscale.xcframework.zip",
            checksum: "293d5d192f0989d5950311b086ddd21b22a41669de5bd1472f47bb257224f6d1"
        ),

        .binaryTarget(
            name: "Libuchardet",
            url: "https://github.com/mpvkit/libuchardet-build/releases/download/0.0.8-xcode/Libuchardet.xcframework.zip",
            checksum: "503202caa0dafb6996b2443f53408a713b49f6c2d4a26d7856fd6143513a50d7"
        ),

        .binaryTarget(
            name: "Libmpv",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-no-lua/Libmpv.xcframework.zip",
            checksum: "1f44a85096682063dd83b73a59b7019d092f0f4495221ed90a71618f375072a3"
        ),
        //AUTO_GENERATE_TARGETS_END//
    ]
)
