import os
import openpyxl

folder = "excel_drops/processed"
for fn in os.listdir(folder):
    if fn.endswith(".xlsx"):
        path = os.path.join(folder, fn)
        wb = openpyxl.load_workbook(path, data_only=True)
        sheet = wb.active
        print(f"\n=== {fn} (Rows: {sheet.max_row}) ===")
        
        # Read all rows and fermenters
        for r in range(2, min(sheet.max_row + 1, 15)):
            f_num = sheet.cell(row=r, column=5).value
            feed_h = sheet.cell(row=r, column=9).value
            ret_h = sheet.cell(row=r, column=10).value
            sg = sheet.cell(row=r, column=30).value
            alc = sheet.cell(row=r, column=33).value
            ph = sheet.cell(row=r, column=37).value
            print(f"  Row {r}: Fermenter={f_num} | FeedH={feed_h} | RetH={ret_h} | FinalSG={sg} | FinalAlc={alc} | FinalPH={ph}")
