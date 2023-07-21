# Data Cleaning and Exploration Using Sql

- Get an overview of the dataset
```sql
Select *
From PortfolioProject..NashvilleHousing
```

---
## Convert SaleDate Column From DateTime data-type format to Date data-type format
- Modify the data type of the "SaleDate" column to the Date data type.
- I did this to to remove the Time displayed as it was unnecessary and unimportant

```sql
Alter Table PortfolioProject..NashvilleHousing 
Alter Column SaleDate Date

```
- Seperate the day, month and year into different columns
```sql
Select
	SaleDate,
	Year(SaleDate) as SaleYear,
	DateName(Month, SaleDate) as SaleMonth,
	Day(SaleDate) as SaleDay
From
PortfolioProject..NashvilleHousing
```

-- Another way is to use the covert function
```sql
Select SaleDate, Convert(Date, Saledate) as SaleDay
From PortfolioProject..NashvilleHousing
```

---
## Populate Property Address data
- The Goal here is to populate the Null values in the PropertyAddress column
- Display rows where propertyAddress is null
```sql
Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is Null
order by 2
```
- Looking at the ParcelID column, you'll see that rows with the same ParcelIDs always have the same PropertyAddress
- So, if we have two or more rows with the same ParcelID, then the propertyAddress of those rows should be the same
- Some rows with the same ParcelID have some of their corresponding PropertyAddress Populated while some are set to Null
- This query is to populate PropertyAddresses that are set to null to match with PropertyAddress that have the same ParcelID as theirs
- First, We join the table with itself where NashA.ParcelID = NashB.ParcelID and where NashA.UniqueID != NashB.UniqueID
- We use the ISNULL command to populate where we have null values
- The ISNULL command here is saying: populate the null rows of NashA.PropertyAddress column with the values in NashB.PropertyAddress

```sql
Select NashA.ParcelID, NashA.PropertyAddress, NashB.ParcelID, NashB.PropertyAddress, ISNULL(NashA.propertyAddress, NashB.propertyAddress)
From PortfolioProject..NashvilleHousing NashA
Join PortfolioProject..NashvilleHousing	NashB
	On NashA.ParcelID = NashB.ParcelID
	And NashA.[UniqueID ] <> NashB.[UniqueID ]
Where NashA.PropertyAddress is NULL
```

- Update the PropertyAddress of NashA table
  
```sql
Update NashA
Set PropertyAddress = ISNULL(NashA.propertyAddress, NashB.propertyAddress)
From PortfolioProject..NashvilleHousing NashA
Join PortfolioProject..NashvilleHousing	NashB
	On NashA.ParcelID = NashB.ParcelID
	And NashA.[UniqueID ] <> NashB.[UniqueID ]
Where NashA.PropertyAddress is NULL
```

---
## Breaking out PropertyAddress into individual columns (Address, City, State)

- The PropertyAddress column contains the address then a comma before the city
- We use the Substring String function to select the first string of text before the comma
- Doing this helps us select just the Address without selecting the city
- Interpreting this query: Select a substring from the PropertyAddress column starting from the first character to the ',' comma's character's index minus 1
- For this second part, We select a substring from PropertyAddress starting from the comma's index + 1: This means we starting from the next character after the comma

```sql
Select 
SubString(PropertyAddress, 1, CharIndex(',', PropertyAddress) - 1) as Address,
SubString(PropertyAddress, CharIndex(',', PropertyAddress) + 1, Len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing
```

- Alter the table by adding a PropertyLocationColumn of type Nvarchar(255)
- Update the table and set the PropertyLocationAddress column we created above to contain our first substring function results for each row

```sql
Alter Table PortfolioProject..NashvilleHousing 
Add PropertyLocationAddress Nvarchar(255)
Update PortfolioProject..NashvilleHousing 
Set PropertyLocationAddress = SubString(PropertyAddress, 1, CharIndex(',', PropertyAddress) - 1)
```

- Alter the table by adding a PropertyCity Column of type Nvarchar(255)
- Update the table and set the PropertyCity column we created above to populate our second substring function results for each row

```sql
Alter Table PortfolioProject..NashvilleHousing 
Add PropertyCity Nvarchar(255)
Update PortfolioProject..NashvilleHousing 
Set PropertyCity = SubString(PropertyAddress, CharIndex(',', PropertyAddress) + 1, Len(PropertyAddress))
```

---
## Breaking out OwnerAddress into individual columns (Address, City, State)
- The OwnerAddress has Address, city, state in one column seperated by two comma.
- You can use a substring function to seperate them into three different columns but a much better and easier way is to use ParseName
- ParseName function is only useful with Period(.). So we have to replace the commas in the string with period(.)
- In the replace function, We specify the column name, the value we want to replace and then the value we want in that position.

```sql
Select 
	ParseName(Replace(OwnerAddress, ',', '.'),1),
	ParseName(Replace(OwnerAddress, ',', '.'),2),
	ParseName(Replace(OwnerAddress, ',', '.'),3)
From PortfolioProject..NashvilleHousing
```

- Alters the table by adding a OwnerLocationColumn of type Nvarchar(255)
- Update the table and populate the OwnerLocation column we created above with the result from parseName function for each row
```sql
Alter Table PortfolioProject..NashvilleHousing 
Add OwnerLocation Nvarchar(255)
Update PortfolioProject..NashvilleHousing 
Set OwnerLocation = ParseName(Replace(OwnerAddress, ',', '.'),3)
```

- Alters the table by adding a OwnerCity Column of type Nvarchar(255)
- Update the table and populate the OwnerCity column we created above with the result from parseName function for each row
Alter Table PortfolioProject..NashvilleHousing 
Add OwnerCity Nvarchar(255)
Update PortfolioProject..NashvilleHousing 
Set OwnerCity = ParseName(Replace(OwnerAddress, ',', '.'),2) 


- Alters the table by adding a OwnerState column of type Nvarchar(255)
- Update the table and populate the OwnerState column we created above with the result from parseName function for each row
Alter Table PortfolioProject..NashvilleHousing 
Add OwnerState Nvarchar(255)
Update PortfolioProject..NashvilleHousing 
Set OwnerState = ParseName(Replace(OwnerAddress, ',', '.'),1)

---
## Change Y and N to Yes and No in SoldAsVacant Column 
- We use a CASE statement to solve this

```sql
Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End 
From PortfolioProject..NashvilleHousing
```
- Update table to reflect changes
```sql
Update PortfolioProject..NashvilleHousing 
Set SoldAsVacant = 
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
End
```

---
## Remove Duplicates
- Its never good practice to delete actual data
- A better way is to create a CTE and remove the duplicates there or use sub-queries
- Using Sub-queries
```sql
Delete From PortfolioProject..NashvilleHousing 
Where [UniqueID ] in (
	Select [UniqueID ]
	From (
		Select *,
			   Row_number() over (Partition by 
					ParcelID, 
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by
						UniqueID
					) as Row_num
		From PortfolioProject..NashvilleHousing 
	) Duplicates_rows 
	Where Duplicates_rows.Row_num > 1
	);
```

- Using a CTE
```sql
With DeleteDuplicatesCTE As (
	Select *,
			Row_number() over (Partition by 
				ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
					UniqueID
				) as Row_num
	From PortfolioProject..NashvilleHousing 
)
```
- To delete Duplicates, Replace Select * with Delete
```sql
Select * 
From DeleteDuplicatesCTE 
Where row_num > 1
```
---
## Delete Unused Columns 
- Columns like the OwnerAddress column can be deleted if necessary
```sql
Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress
```








