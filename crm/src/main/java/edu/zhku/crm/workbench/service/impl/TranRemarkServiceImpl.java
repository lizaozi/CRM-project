package edu.zhku.crm.workbench.service.impl;

import edu.zhku.crm.workbench.domain.TranRemark;
import edu.zhku.crm.workbench.mapper.TranRemarkMapper;
import edu.zhku.crm.workbench.service.TranRemarkService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

/**
 * @author lzw
 * @date 2022/5/8
 * @description
 */
@Service("tranRemarkService")
public class TranRemarkServiceImpl implements TranRemarkService {

    @Resource
    private TranRemarkMapper tranRemarkMapper;

    @Override
    public List<TranRemark> queryTranRemarkByIdForDetail(String tranId) {
        return tranRemarkMapper.selectTranRemarkByTranIdForDetail(tranId);
    }
}
