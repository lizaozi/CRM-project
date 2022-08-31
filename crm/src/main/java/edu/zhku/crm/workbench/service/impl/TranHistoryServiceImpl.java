package edu.zhku.crm.workbench.service.impl;

import edu.zhku.crm.workbench.domain.TranHistory;
import edu.zhku.crm.workbench.mapper.TranHistoryMapper;
import edu.zhku.crm.workbench.service.TranHistoryService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

/**
 * @author lzw
 * @date 2022/5/8
 * @description
 */
@Service("tranHistoryService")
public class TranHistoryServiceImpl implements TranHistoryService {

    @Resource
    private TranHistoryMapper tranHistoryMapper;

    @Override
    public List<TranHistory> queryTranHistoryByTranIdForDetail(String tranId) {
        return tranHistoryMapper.selectTranHistoryByTranIdForDetail(tranId);
    }
}
