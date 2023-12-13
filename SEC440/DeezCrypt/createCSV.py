import csv
from faker import Faker

# Define the number of employees
num_employees = 85

# Create a Faker instance
fake = Faker()

# Create a list to store the employee data
employee_data = []

# Generate fake data for each employee
for _ in range(num_employees):
    name = fake.name()
    dob = fake.date_of_birth(minimum_age=18, maximum_age=65)
    address = fake.address().replace("\n", ", ")
    phone_number = fake.phone_number()
    position_title = fake.job()
    date_hired = fake.date_between(start_date='-5y', end_date='today')
    
    employee_data.append([name, dob, address, phone_number, position_title, date_hired])

# Write the employee data to a CSV file
with open('employee_data.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['Name', 'Date of Birth', 'Address', 'Phone Number', 'Position Title', 'Date Hired'])
    writer.writerows(employee_data)
