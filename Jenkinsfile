library "alauda-cicd-enable-get-multi-arch-image"
def language = "golang"
AlaudaPipeline {
    config = [
        agent: 'golang-1.12',
        folder: '.',
        sonar: [
            binding: "sonarqube",
            enabled: false
        ],
    ]
    env = [
        GO111MODULE: "on",
        GOPROXY: "https://athens.acp.alauda.cn",
		CGO_ENABLED: "0",
		GOOS: "linux",
    ]

    yaml = "alauda.yaml"
}
