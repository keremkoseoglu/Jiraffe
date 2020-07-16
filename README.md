# Jiraffe

Jiraffe is a Mac app which generates alerts whenever a given Jira filter is updated.

![Screenshot](/screenshot.png)

## Prerequisites

Jiraffe is reading your Jira username & password from [Kutapada](https://github.com/keremkoseoglu/kutapada). So, you need to be a Kutapada user in order to use Jiraffe. Ensure that you have installed Kutapada & entered your Jira username & password there.

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

Edit Jiraffe/JiraReader.swift so that JIRAFFE_CONFIG points to this configuration file.

### Kutapada settings

Edit Jiraffe/JiraReader.swift so that: 
- KUTAPADA_CONFIG points to your Kutapada password file on your disk
- KUTAPADA_KEY contains the key value for your Jira password

### Build

Build the project using XCode. 

If you get an error about PasswordFile.swift, mind you that it is hosted under [Kutapada](https://github.com/keremkoseoglu/kutapada). You can copy that file from there.

If the build is successful, all you need to do is to start Jiraffe.app. Voila!

## Usage

Keep the app in the dock. It will generate badges whenever new Jira issues appear in the filters provided.