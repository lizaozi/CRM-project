package edu.zhku.crm.poi;

import org.apache.poi.hssf.usermodel.*;
import org.apache.poi.ss.usermodel.HorizontalAlignment;

import java.io.FileOutputStream;
import java.io.OutputStream;

/**
 * @author lzw
 * @date 2022/4/24
 * @description 使用apache-poi操作Excel文件
 */
public class CreateExcelTest {
    public static void main(String[] args) throws Exception {
        //创建HSSFWorkbook对象，对应一个excel文件
        HSSFWorkbook wb = new HSSFWorkbook();
        //使用wb创建sheet对象，对应wb文件中的一页
        HSSFSheet sheet = wb.createSheet("学生列表");
        //使用sheet创建row对象，对应sheet中的每一行
        HSSFRow row = sheet.createRow(0);//行号，从0开始
        HSSFCell cell = row.createCell(0);//列号，从0开始
        cell.setCellValue("学号");
        cell = row.createCell(1);
        cell.setCellValue("姓名");
        cell = row.createCell(2);
        cell.setCellValue("年龄");

        //生成style样式
        HSSFCellStyle style = wb.createCellStyle();
        style.setAlignment(HorizontalAlignment.CENTER);

        //使用sheet创建10个row对象，对应sheet中的10行
        for (int i = 1;i <= 10;i++) {
            row = sheet.createRow(i);

            cell = row.createCell(0);//列号，从0开始
            cell.setCellStyle(style);
            cell.setCellValue(100 + i);
            cell = row.createCell(1);
            cell.setCellStyle(style);
            cell.setCellValue("name" + i);
            cell = row.createCell(2);
            cell.setCellStyle(style);
            cell.setCellValue(20 + i);
        }

        //调用工具函数，生成excel文件
        OutputStream os = new FileOutputStream("D:\\studentList.xls");
        wb.write(os);
        os.flush();

        //关闭资源
        os.close();
        wb.close();
        System.out.println("=============create ok============");
    }
}
