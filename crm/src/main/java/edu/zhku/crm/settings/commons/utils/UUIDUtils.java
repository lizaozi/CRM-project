package edu.zhku.crm.settings.commons.utils;

import java.util.UUID;

/**
 * @author lzw
 * @date 2022/4/21
 * @description 获取UUID的值
 */
public class UUIDUtils {
    public static String getUUID() {
        return UUID.randomUUID().toString().replaceAll("-","");
    }
}
