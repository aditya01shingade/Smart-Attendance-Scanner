# qr_generator.py
import pandas as pd
import qrcode
import os

# Load student Excel
excel_file = 'students.xlsx'
output_dir = 'qr_output'
os.makedirs(output_dir, exist_ok=True)

try:
    df = pd.read_excel(excel_file)
except Exception as e:
    print(f"❌ Error reading Excel: {e}")
    exit()

required_cols = ['PNR', 'RollNo', 'FirstName', 'LastName', 'Division', 'Department', 'Semester']
if not all(col in df.columns for col in required_cols):
    print(f"❌ Excel must include columns: {required_cols}")
    exit()

# Group and generate QR codes
for _, row in df.iterrows():
    data = f"{row['PNR']},{row['RollNo']},{row['FirstName']},{row['LastName']},{row['Division']}"
    qr = qrcode.make(data)

    dept = row['Department'].replace(' ', '_')
    sem = row['Semester'].replace(' ', '_')
    subdir = os.path.join(output_dir, dept, sem)
    os.makedirs(subdir, exist_ok=True)

    filename = f"{row['RollNo']}_{row['FirstName']}.png"
    qr_path = os.path.join(subdir, filename)
    qr.save(qr_path)

    print(f"✅ Saved: {qr_path}")

print("\n✅ All QR codes generated in:", os.path.abspath(output_dir))
