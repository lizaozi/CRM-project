package edu.zhku.crm.settings.service.impl;

import edu.zhku.crm.settings.domain.DicValue;
import edu.zhku.crm.settings.mapper.DicValueMapper;
import edu.zhku.crm.settings.service.DicValueService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

/**
 * @author lzw
 * @date 2022/4/29
 * @description
 */
@Service("dicValueService")
public class DicValueServiceImpl implements DicValueService {

    @Resource
    private DicValueMapper dicValueMapper;

    @Override
    public List<DicValue> queryDicValueByTypeCode(String typeCode) {
        return dicValueMapper.selectDicValueByTypeCode(typeCode);
    }
}
