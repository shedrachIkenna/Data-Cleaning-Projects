# Data Cleaning Process Using Sql
The following steps shows how I properly cleaning and formatted Fifa21 data set

---
- Get an overview of the dataset ordered by the Ratings in descending pattern
```sql
Select 
	*
From PortfolioProject..Fifa21
Order by Ratings Desc
```
---
- This query renames Rating column to Rating

```sql 
exec sp_rename 'Fifa21.Rating','Ratings'
```

---
## Task: Convert all the values of Height column to cms
* I used the Distinct function to display all unique values in the Height column 
* I found out that some values were displayed in cms while others were displayed in Feet-Inches format

```sql
Select 
	Distinct(Height), 
	Count(Height)
From PortfolioProject..Fifa21
Group by Height
```

* Trying to convert this column directly to decimal data type will result in an error
* Convert values from Feet-Inches to cms
* Select Rows in the height column where the values are in Feet-Inches format

```sql
Select 
	Height
From PortfolioProject..Fifa21
Where Height like '%''%'
```

- I used the CharIndex function to select the position of the Feet values in the substring

```sql
Select 
	Height, 
	CharIndex('''', Height) - 1
From PortfolioProject..Fifa21
Where Height like '%''%'
```

- I also used the CharIndex function to select the position of the Inches values in the substring

```sql
Select 
	Height,
	CharIndex('''', Height) + 1
From PortfolioProject..Fifa21
Where Height like '%''%'
```

- I used the Substring and Charindex function to select the Feet values in the substring

```sql
Select 
	Height, 
	Substring(Height, 1, Charindex('''', Height) - 1)
From PortfolioProject..Fifa21
Where Height like '%''%'
```

- Select the Inches values using the Substring, Charindex and Len functions

```sql
Select 
	Height, 
	Substring(Height, Charindex('''', Height) + 1, Len(Height) - Charindex('''', Height) - 1)
From PortfolioProject..Fifa21
Where Height like '%''%'
```

- Convert the Feet and Inches values to Int data type

```sql
Select 
	Height, 
	Cast(Substring(Height, 1, Charindex('''', Height) - 1) as int) as HeightFeet, 
	Cast(Substring(Height, Charindex('''', Height) + 1, Len(Height) - Charindex('''', Height) - 1) as int) as HeightInches
From PortfolioProject..Fifa21
Where Height like '%''%'
```

- Convert to cm by using the formula
- (FeetValue * 30.48) + (InchesValue * 2.54)

```sql
Select Height, Cast(Substring(Height, 1, Charindex('''', Height) - 1) as int) * 30.48 + Cast(Substring(Height, Charindex('''', Height) + 1, Len(Height) - Charindex('''', Height) - 1) as int) * 2.54
From PortfolioProject..Fifa21
Where Height like '%''%'
```
- Convert the results of the above query to Int in other to remove all decimals

```sql
Select Height, Cast(Cast(Substring(Height, 1, Charindex('''', Height) - 1) as int) * 30.48 + Cast(Substring(Height, Charindex('''', Height) + 1, Len(Height) - Charindex('''', Height) - 1) as int) * 2.54 as Int)
From PortfolioProject..Fifa21
Where Height like '%''%'
```

- Use the case statement and join all the above query

```sql
Select Height,
Case 
	When Height like '%"%'
		Then Cast(Cast(Substring(Height, 1, Charindex('''', Height) - 1) as int) * 30.48 + Cast(Substring(Height, Charindex('''', Height) + 1, Len(Height) - Charindex('''', Height) - 1) as int) * 2.54 as Int)
	Else Height 
End as MainHeight
From PortfolioProject..Fifa21
```

- Update the Height

```sql
Update PortfolioProject..Fifa21
Set Height = 
Case 
	When Height like '%"%'
		Then Cast(Cast(Substring(Height, 1, Charindex('''', Height) - 1) as int) * 30.48 + Cast(Substring(Height, Charindex('''', Height) + 1, Len(Height) - Charindex('''', Height) - 1) as int) * 2.54 as Int)
	Else Height 
End
```
---
## Task: Convert all the values in the Weight column to kg
- I used the Distinct function to display all unique values in the Weight column 
- I found out that some values were displayed in Kg while others were displayed in lbs

```sql
Select Distinct(Weight), Count(Weight)
From PortfolioProject..Fifa21
Group by Weight
```

- Convert values from lbs to kg
- Select Rows in the height column where the values are in Feet-Inches format

```sql
Select Weight
From PortfolioProject..Fifa21
Where Weight like '%lbs%'
```

- Select the numerical value using the Substring and CharIndex function
```sql
Select Weight, Substring(Weight, 1, CharIndex('lbs', weight) - 1)
From PortfolioProject..Fifa21
Where Weight like '%lbs'
```
- Convert to Decimal data type in order to be able to perform the conversion calculation
```sql
Select Weight, Cast(Substring(Weight, 1, CharIndex('lbs', weight) - 1) as Decimal(5, 2))
From PortfolioProject..Fifa21
Where Weight like '%lbs'
```

- Convert lbs to kg by multiplying by 0.45359237
```sql
Select Weight, Cast(Substring(Weight, 1, CharIndex('lbs', weight) - 1) as Decimal(5, 2)) * 0.45359237
From PortfolioProject..Fifa21
Where Weight like '%lbs'
```

- Convert the results of the above query to Int data type in other to remove all decimals
```sql
Select Weight, Cast(Cast(Substring(Weight, 1, CharIndex('lbs', weight) - 1) as Decimal(5, 2)) * 0.45359237 as Int)
From PortfolioProject..Fifa21
Where Weight like '%lbs'
```

- Use the case statement and join all the above query
```sql
Select Weight,
Case 
	When Weight like '%lbs%'
		Then Cast(Cast(Substring(Weight, 1, CharIndex('lbs', weight) - 1) as Decimal(5, 2)) * 0.45359237 as Int) 
	Else Weight
End as MainWeight
From PortfolioProject..Fifa21

-- Update the Weight
Update PortfolioProject..Fifa21
Set Weight = 
Case 
	When Weight like '%lbs%'
		Then Cast(Cast(Substring(Weight, 1, CharIndex('lbs', weight) - 1) as Decimal(5, 2)) * 0.45359237 as Int) 
	Else Weight 
End
```

---
## Separate the joined column into Year, Month and day columns
```sql
Select Joined
From PortfolioProject..Fifa21

Select
	Joined, 
	Year(Joined) as JoinedYear, 
	DateName(Month, Joined) as MonthJoined,
	Day(Joined) as JoinedDay
From 
PortfolioProject..Fifa21
```

---
## Display players playing at a club for more than 10 years
```sql
Select Name, Ratings, Joined
From PortfolioProject..Fifa21
Where Joined <= DateAdd(Year, -10, GetDate())
order by Ratings Desc
```

---
## Transform the value into a column of type decimal
- I used the Distinct function to display all the unique values in the Value column
- FIndings: Some values ended with M, K and 0
```sql
Select Distinct(Value), Count(Value)
From PortfolioProject..Fifa21
Group by Value
```

- Using a Case statement, When the right-most character is K, we use the Substring and Len function to select only the numerical values, use the cast function to convert the value to a decimal data-type and multiply by 1,000
- When the right-most character is M, we use the Substring and Len function to select only the numerical values, use the cast function to convert the value to a decimal data-type and multiply by 1,000,000
- Else we use the Substring and Len function to return the available numerical value which in this case is 0
```sql
Select Value,
	   Case
	    When Right(Value, 1) = 'M' Then Cast(Substring(Value, 4, Len(Value) - 4) As Decimal(16,1)) * 1000000
		When Right(Value, 1) = 'K' Then Cast(Substring(Value, 4, Len(Value) - 4) As Decimal(16,1)) * 1000
		Else Cast(Substring(Value, 4, Len(Value)) as Decimal(5,2))
	   End
From PortfolioProject..Fifa21
```
- Update the Value column to match the above query
```sql
Update PortfolioProject..Fifa21
Set Value = 
Case
	When Right(Value, 1) = 'M' Then Cast(Substring(Value, 4, Len(Value) - 4) As Decimal(16,1)) * 1000000
	When Right(Value, 1) = 'K' Then Cast(Substring(Value, 4, Len(Value) - 4) As Decimal(16,1)) * 1000
	Else Cast(Substring(Value, 4, Len(Value)) as Decimal(5,2))
End
```

---
## Transform the Wage into a decimal data type
- I used the Distinct function to display all the unique values in the Value column
- findings: Some values ended with M, K and 0
```sql
Select Distinct(Wage), Count(Wage)
From PortfolioProject..Fifa21
Group by Wage
```
- Using a Case statement, 
- When the right-most character is K, we use the Substring and Len function to select only the numerical values, use the cast function to convert the value to a decimal data-type and multiply by 1,000
- Else we use the Substring and Len function to return the available numerical value which in this case is 0
```sql
Select Wage,
	   Case
		When Right(Wage, 1) = 'K' Then Cast(Substring(Wage, 4, Len(Wage) -4) as Decimal(16,1)) * 1000
		Else Cast(Substring(Wage, 4, Len(Wage)) as Decimal(16,1)) * 1000
	   End 
From PortfolioProject..Fifa21
```
- Update the Wage column to match the above query
```sql
Update PortfolioProject..Fifa21
Set Wage = 
Case
	When Right(Wage, 1) = 'K' Then Cast(Substring(Wage, 4, Len(Wage) -4) as Decimal(16,1)) * 1000
	Else Cast(Substring(Wage, 4, Len(Wage)) as Decimal(16,1)) * 1000
End
```
---
## Transform the Release Clause into a decimal data type
- I used the Distinct function to display all the unique values in the Value column
- Findings: Some values ended with M, K and 0

```sql
Select Distinct(ReleaseClause), Count(ReleaseClause)
From PortfolioProject..Fifa21
Group by ReleaseClause
```

- Using a Case statement, When the right-most character is K, we use the Substring and Len function to select only the numerical values, use the cast function to convert the value to a decimal data-type and multiply by 1,000
- When the right-most character is M, we use the Substring and Len function to select only the numerical values, use the cast function to convert the value to a decimal data-type and multiply by 1,000,000
- Else we use the Substring and Len function to return the available numerical value which in this case is 0
```sql
Select ReleaseClause,
	   Case
	    When Right(ReleaseClause, 1) = 'M' Then Cast(Substring(ReleaseClause, 4, Len(ReleaseClause) - 4) As Decimal(16,1)) * 1000000
		When Right(ReleaseClause, 1) = 'K' Then Cast(Substring(ReleaseClause, 4, Len(ReleaseClause) - 4) As Decimal(16,1)) * 1000
		Else Cast(Substring(ReleaseClause, 4, Len(ReleaseClause)) as Decimal(5,2))
	   End
From PortfolioProject..Fifa21
```
- Update the ReleaseClause column to match the above query
```sql
Update PortfolioProject..Fifa21
Set ReleaseClause = 
Case
	When Right(ReleaseClause, 1) = 'M' Then Cast(Substring(ReleaseClause, 4, Len(ReleaseClause) - 4) As Decimal(16,1)) * 1000000
	When Right(ReleaseClause, 1) = 'K' Then Cast(Substring(ReleaseClause, 4, Len(ReleaseClause) - 4) As Decimal(16,1)) * 1000
	Else Cast(Substring(ReleaseClause, 4, Len(ReleaseClause)) as Decimal(5,2))
End


-- Pushed Fifa21 dataset
```
