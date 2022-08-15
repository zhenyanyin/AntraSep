#Create a script that will read and parse the given files and remove duplicates using python, 
#then write back into a single CSV

#import packages
import pandas as pd

#import df
df1 = pd.read_csv("PythonAssignments\Assigment1Data\people\people_1.txt", sep='\t')
df2 = pd.read_csv("PythonAssignments\Assigment1Data\people\people_2.txt", sep='\t')

df = pd.concat([df1,df2])

#check dataframe structure
df.head()

#transform data into the same format
#Calpitalize name
df['FirstName'] = df['FirstName'].str.capitalize()
df['LastName'] = df['LastName'].str.capitalize()
#Remove spaces for name
df['FirstName'] = df['FirstName'].str.replace(' ', '')
df['LastName'] = df['LastName'].str.replace(' ', '')

#All lower case for email
df['Email'] = df['Email'].str.lower()
#Remove spaces for email
df['Email'] = df['Email'].str.replace(' ', '')

#Remove all saparators for Phone
df['Phone'] = df['Phone'].str.replace('-', '')
#Remove spaces for Phone
df['Phone'] = df['Phone'].str.replace(' ', '')

#Change house number to No. for Address
df['Address'] = df['Address'].str.replace('#', '')
df['Address'] = df['Address'].str.replace('No.', '')
#Remove spaces for Address
df['Address'] = df['Address'].str.lstrip()
#Add No. in front of house number for Address
df['Address'] = 'No.' + df['Address'].astype(str)

#drop duplicates
new_df=df.drop_duplicates()

#export ad CSV
new_df.to_csv (r"PythonAssignments\Assigment1Data\people\people_full.csv", index = False, header=True)
