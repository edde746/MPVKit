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
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-crash-fix/Libmpv-GPL.xcframework.zip",
            checksum: "c93cad30c66d1995d7495374ee9dc6a62eddf278a3b3c479f319ec5aa565c337"
        ),
        .binaryTarget(
            name: "Libavcodec-GPL",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-crash-fix/Libavcodec-GPL.xcframework.zip",
            checksum: "2b18d11fc98426d198c22a5199b3c8d664f7aef64245c226a6b1f247e8f230a5"
        ),
        .binaryTarget(
            name: "Libavdevice-GPL",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-crash-fix/Libavdevice-GPL.xcframework.zip",
            checksum: "2b29f3d9f3d88247117057ba6a221e7834b3b5180be2d8abf05d4e65f722e539"
        ),
        .binaryTarget(
            name: "Libavformat-GPL",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-crash-fix/Libavformat-GPL.xcframework.zip",
            checksum: "6feea57c0fcdce849a19f952db40adb9b21fed0e59574439cae7b28decaf3ae3"
        ),
        .binaryTarget(
            name: "Libavfilter-GPL",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-crash-fix/Libavfilter-GPL.xcframework.zip",
            checksum: "086e7d2aa022c860704939ea920e91ce915ae6532282b287db76e13c86608744"
        ),
        .binaryTarget(
            name: "Libavutil-GPL",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-crash-fix/Libavutil-GPL.xcframework.zip",
            checksum: "6086343ec5ddc59c0d9e09c42b5a72fd9fcce50d22866d502eed36ee47c5031b"
        ),
        .binaryTarget(
            name: "Libswresample-GPL",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-crash-fix/Libswresample-GPL.xcframework.zip",
            checksum: "18d33ca6264458b20331d40654aecab615075975946564ea5f6f56453dd2ed2c"
        ),
        .binaryTarget(
            name: "Libswscale-GPL",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-crash-fix/Libswscale-GPL.xcframework.zip",
            checksum: "ff36070680ffd6a9633fe9f310f0530b1ba0702f17e57c45cdef416aa15f6a95"
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
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-crash-fix/Libavcodec.xcframework.zip",
            checksum: "c5338fb4a0a21b2bb26f7a3f5cec6cd203dae310aa1bbc66aaf38cd207cea6b0"
        ),
        .binaryTarget(
            name: "Libavdevice",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-crash-fix/Libavdevice.xcframework.zip",
            checksum: "a6db20b9d5f1af91fbfece0f35db1d1f80a2fa1b99583769f4cfa3ac5ac727b2"
        ),
        .binaryTarget(
            name: "Libavformat",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-crash-fix/Libavformat.xcframework.zip",
            checksum: "0a1676887e19f9b76cb01f180a6f8fabfb6d65a2adab30f7af798edf0cb6da94"
        ),
        .binaryTarget(
            name: "Libavfilter",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-crash-fix/Libavfilter.xcframework.zip",
            checksum: "9256ccafe59fe4d94a067853012c7dc2d51a57ea7995ccbd3b0c212d71b81f3d"
        ),
        .binaryTarget(
            name: "Libavutil",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-crash-fix/Libavutil.xcframework.zip",
            checksum: "92dd479d3954a6e8836421de33f346827965f2540593739f85a3e5e9fd6b8160"
        ),
        .binaryTarget(
            name: "Libswresample",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-crash-fix/Libswresample.xcframework.zip",
            checksum: "434b87dfbc3f458264f53d29ac6c6ded6259bc3a52620ee065cda59216cb31bf"
        ),
        .binaryTarget(
            name: "Libswscale",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-crash-fix/Libswscale.xcframework.zip",
            checksum: "80e00e6e373db7fd8afed1cbef4897345437f09c474ed26e595c3acbf2ac7db3"
        ),

        .binaryTarget(
            name: "Libuchardet",
            url: "https://github.com/mpvkit/libuchardet-build/releases/download/0.0.8-xcode/Libuchardet.xcframework.zip",
            checksum: "503202caa0dafb6996b2443f53408a713b49f6c2d4a26d7856fd6143513a50d7"
        ),

        .binaryTarget(
            name: "Libmpv",
            url: "https://github.com/edde746/MPVKit/releases/download/0.40.0-crash-fix/Libmpv.xcframework.zip",
            checksum: "bac6192abb0cc1f84e52fefe05bd19f150f355fdeef179a2a1a42d32c8c4dc9d"
        ),
        //AUTO_GENERATE_TARGETS_END//
    ]
)
