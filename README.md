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

Edit Jiraffe/JiraReader.swift so that JIRAFFE_CONFIG points to this configuration file.

If you want to change the Jira check frequency, you can edit Jiraffe/Model.swift - schedule().

### Credential settings

#### Alternative 1: Kutapada

Current version of Jiraffe is reading your Jira username & password from [Kutapada](https://github.com/keremkoseoglu/kutapada). If you like it that way, you need to be a Kutapada user in order to use Jiraffe. Ensure that you have installed Kutapada & entered your Jira username & password there.

Edit Jiraffe/JiraReader.swift so that: 
- KUTAPADA_CONFIG points to your Kutapada password file on your disk
- KUTAPADA_KEY contains the key value for your Jira password

#### Alternative 2: Hard Code

If you don't want to use [Kutapada](https://github.com/keremkoseoglu/kutapada), you can simply edit Jiraffe/JiraReader.swift to:
- Put your hard coded username & password into the variables jiraUser & jiraPass. You can also get creative and fill them using some other method.
- Delete the function readKutapadaConfig and its references
- Delete  KUTAPADA_* variables

### Build

Build the project using XCode. 

If you get an error about PasswordFile.swift;
- If you are reading credentials from Kutapada, you need that file. It is hosted under [Kutapada](https://github.com/keremkoseoglu/kutapada). You can copy that file from there.
- If you aren't using Kutapada, you can simply remove PasswordFile.swift from the project references and move on.

If the build is successful, all you need to do is to start Jiraffe.app. Voila!

## Usage

Keep the app in the dock. It will generate badges whenever new Jira issues appear in the filters provided.