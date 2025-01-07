package main

import (
	"fmt"
	"runtime"

	"github.com/xfab-hari/release-workflow/cmd"
)

var version = "dev"

func main() {
	fmt.Println("Example Running:", version, runtime.GOOS, runtime.GOARCH)
	cmd.Execute()
}
