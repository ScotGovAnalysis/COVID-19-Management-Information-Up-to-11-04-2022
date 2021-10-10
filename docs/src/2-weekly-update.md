# Weekly update

This section details the weekly update process. It assumes that you already have the project's GitHub repository downloaded and correctly set up. If it is your first time maintaining this project, or you need to set up the GitHub repository, please read the next section.

## Step 1: Pulling the latest version of the GitHub repository

This step is only necessary if you want to use Git Bash. Using Git Bash is strongly recommended. You can skip it if you are going to upload files on to GitHub manually.

If you aren't working in a project cloned from GitHub, please follow the instructions in the PROJECT SETUP section before proceeding.

1. Open the project in RStudio: `COVID-19-Management-Information.Rproj`.
2. In the RStudio Terminal tab, run `git pull origin master`.

![](images/original/1-git-pull.png)

This will update all files in the project to the latest version uploaded to GitHub.

## Step 2: Running the R code

1. Open the main R script: `COVID-19-Management-Information.r`.
2. Click "Source" to run the R code.

![](images/r/source.png)

The console will output its progress as it converts each Excel worksheet to CSV format. You will be notified when the script has successfully finished running.

![](images/r/console-output.png)

> If you double click on the main script, RStudio will open with the folder the script is as the working directory.

> The `scripts/` folder contains R scripts that are called by the main script. They will not work when run stand-alone.

## Step 3: Uploading the new data sets to GitHub

All the output files should have been created in the `export/` folder.

1. Run `git status` in the Terminal to confirm.

![](images/original/2-git-status.png)

2. Run `git add .` (git add period) to stage the changes.
3. Run `git commit -m "type your own commit message here"` to commit the changes.

![](images/original/3-git-commit.png)

The commit message will appear in the git history, and will show next to the files when viewing on GitHub.

4. Run `git push origin master` to push the files from your local repository to GitHub.

![](images/original/4-git-push.png)

The changes should then be visible on the remote repository.

## Manually the new data sets to GitHub

Alternatively (though not recommended), you can upload the new data sets to GitHub through GitHub's web interface.

1. Go to the GitHub folder:  
   https://github.com/DataScienceScotland/COVID-19-Management-Information
2. Click on "Upload files" and select all the files to upload.
3. Scroll down to the bottom of the page and click on "Commit changes".

## Step 4: Uploading the new data sets to statistics.gov.scot

1. Navigate to statistics.gov.scot admin site and log in:  
   [https://pmd3-production-admin-sg.publishmydata.com/admin](https://pmd3-production-admin-sg.publishmydata.com/admin)
2. Go to the Covid-19 – Management Information dataset:  
   [https://pmd3-production-admin-sg.publishmydata.com/resource?uri=http%3A%2F%2Fstatistics.gov.scot%2Fdata%2Fcoronavirus-covid-19-management-information](https://pmd3-production-admin-sg.publishmydata.com/resource?uri=http%3A%2F%2Fstatistics.gov.scot%2Fdata%2Fcoronavirus-covid-19-management-information)
3. Click on "EDIT" tab and then on "CLEAR DATASET CONTENTS"

![](images/original/5-web-clear.png)

Once you make any changes to the dataset, the system will automatically create a new draft called "Untitled". You can rename it if you like, but since this is the only one you will have in your accounts and it"s going to be used for 30 minutes, you can leave it unchanged.

4. Click on the "PIPELINES" tab and then on the first type of pipeline – Spreadsheet to datacube.

![](images/original/6-web-pipeline.png)

5. Select the "Coronavirus – COVID-19 – Management Information" dataset as the target dataset and `export/upload-to-open-data-platform.csv` as the input data.

![](images/original/7-web-upload.png)

6. Run the pipeline.

## Step 5: Quality Assurance for statistics.gov.scot

1. Click on the dataset and go to the "API" tab. Check the number of observations under the "DATA LINKED RESOURCES" section.
2. Download the whole dataset as "CSV" and compare the number of observations. Numbers should match.
3. Select a slice of the dataset and check it downloads fine.
4. Go to "TOOLS/SPARQL Query" and run the SPARQL queries in the section below, one query at a time. Make sure you check "Validates URIs".

![](images/original/8-sparql-uris.png)

5. All the queries should give no results and all the URIs should come up in green.

![](images/original/9-sparql-valid.png)

## Step 6: Publish on statistics.gov.scot

1. Publish the draft by clicking on Publish at the top of the window.

![](images/original/10-web-publish.png)

![](images/original/11-web-confirm.png)
