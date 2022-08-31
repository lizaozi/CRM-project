package edu.zhku.crm.settings.commons.utils;

import org.apache.poi.hssf.usermodel.HSSFCell;

/**
 * @author lzw
 * @date 2022/4/27
 * @description 关于excel文件操作的工具类
 */
public class HSSFUtils {

    /**
     * 从指定的HSSFCell对象中获取列的值
     * @param cell
     * @return
     */
    public static String getCellValueForStr(HSSFCell cell) {
        String result = "";
        if (cell.getCellType() == HSSFCell.CELL_TYPE_STRING) {
            result = cell.getStringCellValue();
        }else if (cell.getCellType() == HSSFCell.CELL_TYPE_NUMERIC) {
            result = cell.getNumericCellValue() + "";
        }else if (cell.getCellType() == HSSFCell.CELL_TYPE_BOOLEAN) {
            result = cell.getBooleanCellValue() + "";
        }else if (cell.getCellType() == HSSFCell.CELL_TYPE_FORMULA) {
            result = cell.getCellFormula();
        }else {
            result = "";
        }
        return result;
    }
}
