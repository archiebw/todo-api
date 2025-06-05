package config

import (
	"os"
	"strconv"

	"github.com/labstack/gommon/log"
)

type EnvConfig struct {
	LOG_LEVEL                      log.Lvl
	ENVIRONMENT                    string
	PORT                           int
	GOOGLE_APPLICATION_CREDENTIALS string
	GOOGLE_FIRESTORE_PROJECT       string
}

// LoadEnv reads environment variables into the struct
func LoadEnv() *EnvConfig {
	cfg := &EnvConfig{
		LOG_LEVEL:                ParseLogLevel(os.Getenv("LOG_LEVEL")),
		ENVIRONMENT:              os.Getenv("ENVIRONMENT"),
		PORT:                     parsePort(os.Getenv("PORT")),
		GOOGLE_FIRESTORE_PROJECT: os.Getenv("GOOGLE_FIRESTORE_PROJECT"),
	}
	return cfg
}

func ParseLogLevel(level string) log.Lvl {
	switch level {
	case "DEBUG":
		return log.DEBUG
	case "INFO":
		return log.INFO
	case "WARN":
		return log.WARN
	case "ERROR":
		return log.ERROR
	case "OFF":
		return log.OFF
	}
	return log.OFF
}

func parsePort(port string) int {
	value, _ := strconv.Atoi(port)
	return value
}
