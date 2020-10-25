package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"gopkg.in/yaml.v3"
	"io/ioutil"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"testing"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
)

type User = struct {
	Name string
	Username string
	Email string
	Groups []string
}

type Project = struct {
	Name string
	Groupname string `yaml:"group_name"`
}

func TestTerraformGitlabUsersGroupsProjects(t *testing.T) {
	//terraformOptions := &terraform.Options{
	//	TerraformDir: ".",
	//	Parallelism: 1,
	//}

	terraformOptionsNoLogger := &terraform.Options{
		TerraformDir: ".",
		Parallelism: 1,
		Logger: logger.Discard,
	}

	gitlab_token := os.Getenv("TF_VAR_gitlab_token")

	users := make(map[string]User)
	filename, _ := filepath.Abs("./users_extra.yaml")
	yamlFile, _ := ioutil.ReadFile(filename)
	yaml.Unmarshal(yamlFile, &users)
	projects := make(map[string]Project)
	filename, _ = filepath.Abs("./projects_extra.yaml")
	yamlFile, _ = ioutil.ReadFile(filename)
	yaml.Unmarshal(yamlFile, &projects)

	defer terraform.Destroy(t, terraformOptionsNoLogger)

	terraform.InitAndApply(t, terraformOptionsNoLogger)

	//output := terraform.Output(t, terraformOptions, "hello_world")
	t.Run("User creation", func(t *testing.T) {
		for _, user := range(users) {
			ok, reason := validateUser(t, gitlab_token, user.Email)
			if !ok {
				t.Errorf("Users failed with reason: %s", reason)
			}
		}
	})

	t.Run("Project creation", func(t *testing.T) {
		for _, project := range(projects) {
			ok, reason := validateProject(t, gitlab_token, project)
			if !ok {
				t.Errorf("Project failed with reason: %s", reason)
			}
		}
	})
}

func validateUser(t *testing.T, token string, email string) (result bool, reason string) {
	url := fmt.Sprintf("http://localhost:8080/api/v4/users?search=%s", email)
	headers := map[string]string{
		"Private-Token": token,
	}
	// var body io.Reader
	statusCode, content := http_helper.HTTPDo(t, "GET", url, nil, headers, nil)
	//t.Logf("status code: %d from URL %s", statusCode, url)
	//t.Logf("body: %s", content)

	if statusCode != 200 {
		return false, fmt.Sprintf("User not found. Received status code: %d", statusCode)
	}

	if !strings.Contains(content, email) {
		return false, fmt.Sprintf("Email: %s not found in returned content: %s", email, content)
	}

	return true, ""
}

func validateProject(t *testing.T, token string, project Project) (result bool, reason string) {
	url := fmt.Sprintf("http://localhost:8080/api/v4/projects?search=%s", url.QueryEscape(project.Name))
	headers := map[string]string{
		"Private-Token": token,
	}
	// var body io.Reader
	statusCode, content := http_helper.HTTPDo(t, "GET", url, nil, headers, nil)
	//t.Logf("status code: %d from URL %s", statusCode, url)
	//t.Logf("===\nReceived content: %s\n===", content)

	if statusCode != 200 {
		return false, fmt.Sprintf("Project not found. Received status code: %d", statusCode)
	}

	if !strings.Contains(content, project.Name) {
		return false, fmt.Sprintf("Email: %s not found in returned content: %s", project.Name, content)
	}

	return true, ""
}
