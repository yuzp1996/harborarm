library "alauda-cicd"
def language = "golang"
AlaudaPipeline {
    config = [
        agent: 'harborbuild',
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