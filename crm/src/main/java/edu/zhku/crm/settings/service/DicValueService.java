package edu.zhku.crm.settings.service;

import edu.zhku.crm.settings.domain.DicValue;

import java.util.List;

/**
 * @author lzw
 * @date 2022/4/29
 * @description
 */
public interface DicValueService {
    List<DicValue> queryDicValueByTypeCode(String typeCode);
}
