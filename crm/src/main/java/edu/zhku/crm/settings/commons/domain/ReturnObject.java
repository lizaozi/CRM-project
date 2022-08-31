package edu.zhku.crm.settings.commons.domain;

import lombok.Data;

/**
 * @author lzw
 * @date 2022/4/18
 * @description
 */
@Data
public class ReturnObject {
    private String code; //处理成功或者失败的标志，1---成功，0----失败
    private String message;//提示信息
    private Object retData;//其他信息
}
