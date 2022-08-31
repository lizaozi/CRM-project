package edu.zhku.crm.settings.commons.utils;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * @author lzw
 * @date 2022/4/20
 * @description 对Date对象进行格式化
 */
public class DateUtils {
    /**
     * 对指定的date对象进行格式化：yyyy-MM-dd hh:mm:ss
     * @param date
     * @return
     */
    public static String formatDateTime(Date date) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String dateStr = sdf.format(date);
        return dateStr;
    }
}
