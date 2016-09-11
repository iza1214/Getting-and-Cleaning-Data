install.packages('downloader')
install.packages("reshape2")
library("reshape2")

## Download and unzip the dataset:
filename <- "./Data/smartphones.zip"
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
download.file(fileURL, filename, method="curl")

unzip(filename) 
list.files ("./UCI HAR Dataset")

# 1. Extract only the data on mean and standard deviation
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

ExtractData <- grep(".*mean.*|.*std.*", features[,2])
ExtractData.names <- features[ExtractData,2]
ExtractData.names = gsub('-mean', 'Mean', ExtractData.names)
ExtractData.names = gsub('-std', 'Std', ExtractData.names)
ExtractData.names <- gsub('[-()]', '', ExtractData.names)

# 2. Merges the training and the test sets to create one data set.
training <- read.table("UCI HAR Dataset/train/X_train.txt")[ExtractData]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
training <- cbind(trainSubjects, trainActivities, training)

#check data
head(training)


test <- read.table("UCI HAR Dataset/test/X_test.txt")[ExtractData]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

#check data
head(test)

# 3. Merge datasets together
mergedData <- rbind(training, test)
colnames(mergedData) <- c("subject", "activity", ExtractData.names)

#check merge
head(mergedData)

# 4. Recode the values and label
activitylabel <- read.table("UCI HAR Dataset/activity_labels.txt")
activitylabel[,2] <- as.character(activitylabel[,2])

mergedData$activity <- factor(mergedData$activity, levels = activitylabel[,1], labels = activitylabel[,2])
mergedData$subject <- as.factor(mergedData$subject)

head(mergedData)

#Final tidy dataset with average of each variable for each activity and each subject.

mergedData.melted <- melt(mergedData, id = c("subject", "activity"))
mergedData.mean <- dcast(mergedData.melted, subject + activity ~ variable, mean)

write.table(mergedData.mean, "tidy_data.txt", row.names = FALSE, quote = FALSE)


