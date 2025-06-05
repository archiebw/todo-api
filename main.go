package main

import (
	"fmt"
	"net/http"
	"todo/internal/config"
	"todo/internal/firestoredb"
	"todo/internal/memorydb"
	"todo/internal/models"
	"todo/internal/repositories"

	"github.com/labstack/echo-contrib/prometheus"
	"github.com/labstack/echo/v4"
	"github.com/labstack/gommon/log"
)

var e *echo.Echo
var db repositories.Todo
var env *config.EnvConfig

func main() {
	loadConfig()
	setupEcho()
	setupDB()
	port := fmt.Sprintf(":%d", env.PORT)
	e.Logger.Fatal(e.Start(port))
}

func loadConfig() {
	env = config.LoadEnv()
}

func setupEcho() {
	e = echo.New()
	p := prometheus.NewPrometheus("echo", nil)
	p.Use(e)
	e.Logger.SetLevel(log.DEBUG)
	e.Logger.Info("Setting up routes...")
	setupRouting(e)
}

func setupDB() {
	switch env.ENVIRONMENT {
	case "PRODUCTION":
		setupFirestore()
	case "LOCAL":
		db = memorydb.New()
	default:
		db = memorydb.New()
	}
}

func setupFirestore() {
	e.Logger.Info("Initialising DB...")
	var err error
	db, err = firestoredb.New("archiebw-todo")
	if err != nil {
		e.Logger.Fatal("Failed to initialise firestore db...")
	}
}

func setupRouting(e *echo.Echo) {
	e.GET("/todo/", getAllTodo)
	e.GET("/todo/:id", getTodo)
	e.POST("/todo", saveTodo)
	e.PUT("/todo/:id", updateTodo)
	e.DELETE("/todo/:id", deleteTodo)
}

func getAllTodo(c echo.Context) error {
	e.Logger.Info("GET - todo")
	t, err := db.GetAllTodos()
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError)
	}
	return c.JSON(http.StatusOK, t)
}

func getTodo(c echo.Context) error {
	id := c.Param("id")
	e.Logger.Infof("GET - todo/%d", id)
	t, err := db.GetTodoByID(id)
	if err != nil {
		return echo.NewHTTPError(http.StatusNotFound, err.Error())
	}
	return c.JSON(http.StatusOK, t)
}

func saveTodo(c echo.Context) error {
	t := new(models.Todo)
	if err := c.Bind(t); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest)
	}
	e.Logger.Infof("POST - /todo %d", t.ID)
	if err := db.CreateTodo(t); err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}
	return c.JSON(http.StatusCreated, t)
}

func updateTodo(c echo.Context) error {
	t := new(models.Todo)
	if err := c.Bind(t); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest)
	}
	e.Logger.Infof("POST - /todo/%d", t.ID)
	if err := db.UpdateTodoByID(t); err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError)
	}
	return c.JSON(http.StatusAccepted, t)
}

func deleteTodo(c echo.Context) error {
	id := c.Param("id")
	e.Logger.Infof("DELETE - todo/%d", id)
	err := db.DeleteTodoByID(id)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError)
	}
	return c.NoContent(http.StatusNoContent)
}
