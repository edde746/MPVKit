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
                .target(name: "Libluajit", condition: .when(platforms: [.macOS])),
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
                .target(name: "Libluajit", condition: .when(platforms: [.macOS])),
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
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.40.0-resize-fix/Libmpv-GPL.xcframework.zip",
            checksum: "df81a62a8e4205ab7d03a4ed48491405515ea6df5f9ddd921723e411104c2e27"
        ),
        .binaryTarget(
            name: "Libavcodec-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.40.0-resize-fix/Libavcodec-GPL.xcframework.zip",
            checksum: "1c6d4f76eb2c27db28a59cb279172dbd477319bdd1282aa293c6aa44d6984bf4"
        ),
        .binaryTarget(
            name: "Libavdevice-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.40.0-resize-fix/Libavdevice-GPL.xcframework.zip",
            checksum: "1b40f8b43ef418ac989af736226f6617ca1ed86682f114f7523ff154237961a7"
        ),
        .binaryTarget(
            name: "Libavformat-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.40.0-resize-fix/Libavformat-GPL.xcframework.zip",
            checksum: "6c47b73ee86d72bc0c551712fd3749c370c87c0c39da3aaffb7990b68500bf50"
        ),
        .binaryTarget(
            name: "Libavfilter-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.40.0-resize-fix/Libavfilter-GPL.xcframework.zip",
            checksum: "c8b541c329712fcfad9984bd979098b63e9dcc005bcbebb72dc70d3f3e9794ea"
        ),
        .binaryTarget(
            name: "Libavutil-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.40.0-resize-fix/Libavutil-GPL.xcframework.zip",
            checksum: "ea9bdeadfea8ca3c7fcebccce1c78408c68d34f54cdbdc4d7e8d948a5b23fe15"
        ),
        .binaryTarget(
            name: "Libswresample-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.40.0-resize-fix/Libswresample-GPL.xcframework.zip",
            checksum: "8fa267544cdf4feb456f6020136e4cd571eab641506bd0ebee3b9e4cbaf64736"
        ),
        .binaryTarget(
            name: "Libswscale-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.40.0-resize-fix/Libswscale-GPL.xcframework.zip",
            checksum: "d2ba2f7aa2386baea8ee98454847712a19a2567889f88901958de1ea18ee6c64"
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
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.40.0-resize-fix/Libavcodec.xcframework.zip",
            checksum: "6a75eaba2c8d231ffb39d2b3e452b033abdd68ac77f3e99821243f0d1a60f06d"
        ),
        .binaryTarget(
            name: "Libavdevice",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.40.0-resize-fix/Libavdevice.xcframework.zip",
            checksum: "0649b3b0c00d4da10b79b76a689b5a70b41542682e97562022b89af7936e386f"
        ),
        .binaryTarget(
            name: "Libavformat",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.40.0-resize-fix/Libavformat.xcframework.zip",
            checksum: "2d3a1fd08ee5b70a2dcdb6d8f0fa35603b5573342f13a79d50220c28b89ffbaf"
        ),
        .binaryTarget(
            name: "Libavfilter",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.40.0-resize-fix/Libavfilter.xcframework.zip",
            checksum: "bd3ae072654b1c7d4578b74c3da8e06b4cde009681bb40030414f66786bc67bd"
        ),
        .binaryTarget(
            name: "Libavutil",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.40.0-resize-fix/Libavutil.xcframework.zip",
            checksum: "4d7a2dba4b258ec30ad39993efbe8a4bee86ffb92bcdde241ca2f2771182ed4e"
        ),
        .binaryTarget(
            name: "Libswresample",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.40.0-resize-fix/Libswresample.xcframework.zip",
            checksum: "782af8f48b41d7921dfa3f222db8914a37674b11d4494f6e43d1aacbd1ad6355"
        ),
        .binaryTarget(
            name: "Libswscale",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.40.0-resize-fix/Libswscale.xcframework.zip",
            checksum: "638021fa62007bf72a5699f49cd0e18bebb513bd9280822aa4fb5d0b9e6409ec"
        ),

        .binaryTarget(
            name: "Libuchardet",
            url: "https://github.com/mpvkit/libuchardet-build/releases/download/0.0.8-xcode/Libuchardet.xcframework.zip",
            checksum: "503202caa0dafb6996b2443f53408a713b49f6c2d4a26d7856fd6143513a50d7"
        ),

        .binaryTarget(
            name: "Libluajit",
            url: "https://github.com/mpvkit/libluajit-build/releases/download/2.1.0-xcode/Libluajit.xcframework.zip",
            checksum: "8e76f267ee100ff5f3bbde7641b2240566df722241cdf8e135be7ef3d29e237a"
        ),

        .binaryTarget(
            name: "Libmpv",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.40.0-resize-fix/Libmpv.xcframework.zip",
            checksum: "fb2f616f4f3bf22d88419292ef564775acf86edcbcdb51216b68c27cccb64180"
        ),
        //AUTO_GENERATE_TARGETS_END//
    ]
)
