import xlrd
def readXlsx(path,sheetName):
    try:
        workbook = xlrd.open_workbook(path)
        sheet = workbook.sheet_by_name(sheetName)
    except Exception:
        print(Exception)
    dict = {}

    for i in range(sheet.ncols):
        for j in range(sheet.nrows):
            dict[sheet.cell_value(0, i)] = sheet.cell_value(j+1,i)




if __name__ == '__main__':
    readXlsx("data\catalog.xlsx","all L2 increasing")

