# Jiraffe

Jiraffe is a Mac app which generates alerts whenever a given Jira filter is updated.

![Screenshot](/screenshot.png)

## Installation

### Copying files

Create a folder called Jiraffe, and download all project files there.

### Jiraffe settings

Create a file called "jiraffe.json" somewhere, which should have the following format:

```
{
    "filters": [
        {
            "name": "Request",
            "url": "https://yourjiraserver.com/rest/api/2/search?jql=filter=11053",
            "replied": false,
            "reply": {"total": 0, "issues": []},
            "prevReply": {"total": 0, "issues": []}
        }
    ]
}
```

Create a file called "jiraffe_acc.json" somewhere, which should have the following format:

```
{
    "accounts": [
        {
            "webAlias": "Jira",
            "url": "https://yourjiraserver.com",
            "username": "username",
            "password": "password",
            "apiKey": "api_key",
            "projects": [
                "VOL"
            ]
        }
    ]
}
```

You need to fill the password field for basic authentication of on-premise servers and the apiKey field for API based access of Jira Cloud. More info for API key generation can be found here: https://id.atlassian.com/manage-profile/security/api-tokens

Edit Jiraffe/JiraReader.swift so that JIRAFFE_CONFIG and ACC_CONFIG point to these configuration files.

If you want to change the Jira check frequency, you can edit Jiraffe/Model.swift - schedule().

### Build

Build the project using XCode. If the build is successful, all you need to do is to start Jiraffe.app. Voila!

## Usage

Keep the app in the dock. It will generate badges whenever new Jira issues appear in the filters provided.
