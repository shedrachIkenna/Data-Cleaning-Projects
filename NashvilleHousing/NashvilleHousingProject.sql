Select *
From PortfolioProject..NashvilleHousing 

--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Converted SaleDate Column From DateTime data-type format to Date data-type format
-- I did this to to remove the Time displayed as it was unnecessary and unimportant 
--------------------------------------------------------------------------------------------------------------------------------------------------------
Alter Table PortfolioProject..NashvilleHousing 
Alter Column SaleDate Date

Select SaleDate 
From PortfolioProject..NashvilleHousing

Select
	SaleDate,
	Year(SaleDate) as SaleYear,
	DateName(Month, SaleDate) as SaleMonth,
	Day(SaleDate) as SaleDay
From
PortfolioProject..NashvilleHousing

-- This is another way of doing it but the result appears on a different column
Select SaleDate, Convert(Date, Saledate) as SaleDay
From PortfolioProject..NashvilleHousing 

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data
-------------------------------------------------------------------------------------------------------------------------------------------------------
--The Goal here is to populate the Null values in the PropertyAddress column
--If you look at the ParcelID column, you'll see that rows with the same ParcelIDs always have the same PropertyAddress
--So, if we have two or more rows with the same ParcelID, then the propertyAddress of those rows should be the same
Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is Null
order by 2

--Some rows with the same ParcelID have some of their corresponding PropertyAddress Populated while some are set to Null
--This query is to populate these PropertyAddress that are set to null to match with PropertyAddress that have the same ParcelID as theirs
--First, We join the table with itself where NashA.ParcelID = NashB.ParcelID and where NashA.UniqueID != NashB.UniqueID
--We use the ISNULL command to populate where we have null values
--The ISNULL command here is saying - populate the null rows of NashA.PropertyAddress column with the values in NashB.PropertyAddress
Select NashA.ParcelID, NashA.PropertyAddress, NashB.ParcelID, NashB.PropertyAddress, ISNULL(NashA.propertyAddress, NashB.propertyAddress)
From PortfolioProject..NashvilleHousing NashA
Join PortfolioProject..NashvilleHousing	NashB
	On NashA.ParcelID = NashB.ParcelID
	And NashA.[UniqueID ] <> NashB.[UniqueID ]
Where NashA.PropertyAddress is NULL

-- Update the PropertyAddress of NashA table
Update NashA
Set PropertyAddress = ISNULL(NashA.propertyAddress, NashB.propertyAddress)
From PortfolioProject..NashvilleHousing NashA
Join PortfolioProject..NashvilleHousing	NashB
	On NashA.ParcelID = NashB.ParcelID
	And NashA.[UniqueID ] <> NashB.[UniqueID ]
Where NashA.PropertyAddress is NULL


----------------------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out PropertyAddress into individual columns (Address, City, State)
----------------------------------------------------------------------------------------------------------------------------------------------------
-- The PropertyAddress column contains the address then a comma before the city
-- We use the Substring String function to select the first string of text before the comma
-- Doing this helps us select just the Address without selecting the city
-- Interpreting this query 
-- Select a substring from the PropertyAddress starting from the first character
-- to the ',' comma's character's index minus 1 

Select 
SubString(PropertyAddress, 1, CharIndex(',', PropertyAddress) - 1) as Address,
--For this second part, We select a substring from PropertyAddress starting from the comma's index + 1
--This means we starting from the next character after the comma
SubString(PropertyAddress, CharIndex(',', PropertyAddress) + 1, Len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

-- Alters the table by adding a PropertyLocationColumn of type Nvarchar(255)
Alter Table PortfolioProject..NashvilleHousing 
Add PropertyLocationAddress Nvarchar(255)
-- Update the table and set the PropertyLocationAddress column we created above to contain our first substring function results for each row
Update PortfolioProject..NashvilleHousing 
Set PropertyLocationAddress = SubString(PropertyAddress, 1, CharIndex(',', PropertyAddress) - 1) 

-- Alters the table by adding a PropertyCity Column of type Nvarchar(255)
Alter Table PortfolioProject..NashvilleHousing 
Add PropertyCity Nvarchar(255)
-- Updates the table and set the PropertyCity column we created above to populate our second substring function results for each row 
Update PortfolioProject..NashvilleHousing 
Set PropertyCity = SubString(PropertyAddress, CharIndex(',', PropertyAddress) + 1, Len(PropertyAddress)) 

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out OwnerAddress into individual columns (Address, City, State)
----------------------------------------------------------------------------------------------------------------------------------------------------
-- The OwnerAddress has Address, city, state in one column seperated by two comma.
-- You can use a substring function to seperate them into three different columns but a much better and easier way is to use ParseName
-- ParseName function is only useful with Period(.). So we have to replace the commas in the string with period(.)
-- In the replace function, We specify the column name, the value we want to replace and then the value we want in that position.
Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select 
ParseName(Replace(OwnerAddress, ',', '.'),1),
ParseName(Replace(OwnerAddress, ',', '.'),2),
ParseName(Replace(OwnerAddress, ',', '.'),3)
From PortfolioProject..NashvilleHousing 


-- Alters the table by adding a OwnerLocationColumn of type Nvarchar(255)
Alter Table PortfolioProject..NashvilleHousing 
Add OwnerLocation Nvarchar(255)
-- Update the table and populate the OwnerLocation column we created above with the result from parseName function for each row
Update PortfolioProject..NashvilleHousing 
Set OwnerLocation = ParseName(Replace(OwnerAddress, ',', '.'),3)

-- Alters the table by adding a OwnerCity Column of type Nvarchar(255)
Alter Table PortfolioProject..NashvilleHousing 
Add OwnerCity Nvarchar(255)
-- Update the table and populate the OwnerCity column we created above with the result from parseName function for each row
Update PortfolioProject..NashvilleHousing 
Set OwnerCity = ParseName(Replace(OwnerAddress, ',', '.'),2) 


-- Alters the table by adding a OwnerState column of type Nvarchar(255)
Alter Table PortfolioProject..NashvilleHousing 
Add OwnerState Nvarchar(255)
-- Update the table and populate the OwnerState column we created above with the result from parseName function for each row
Update PortfolioProject..NashvilleHousing 
Set OwnerState = ParseName(Replace(OwnerAddress, ',', '.'),1)

-----------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in SoldAsVacant Column 
-----------------------------------------------------------------------------------------------------------------
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing 
Group by SoldAsVacant
Order by 2

--We use a CASE statement to solve this
-- CASE statement is a conditional statement
Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End 
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing 
Set SoldAsVacant = 
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
End

-------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
-------------------------------------------------------------------------------------------------------------------------------
-- Its never good practice to delete actual data
-- A better way is to create a CTE and remove the duplicates there or use sub-queries
-- Using Sub-queries
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

-- Using a CTE
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
-- To delete Duplicates, Replace Select * with Delete 
Select * 
From DeleteDuplicatesCTE 
Where row_num > 1

---------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns 
---------------------------------------------------------------------------------------------------------------------------------
Select *
From PortfolioProject..NashvilleHousing 

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress

-- Pushed Nashville Housing Dataset



