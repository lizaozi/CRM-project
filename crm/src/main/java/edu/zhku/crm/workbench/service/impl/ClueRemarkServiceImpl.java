package edu.zhku.crm.workbench.service.impl;

import edu.zhku.crm.workbench.domain.ClueRemark;
import edu.zhku.crm.workbench.mapper.ClueMapper;
import edu.zhku.crm.workbench.mapper.ClueRemarkMapper;
import edu.zhku.crm.workbench.service.ClueRemarkService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

/**
 * @author lzw
 * @date 2022/5/2
 * @description
 */
@Service("clueRemarkService")
public class ClueRemarkServiceImpl implements ClueRemarkService {

    @Resource
    private ClueRemarkMapper clueRemarkMapper;

    @Override
    public List<ClueRemark> queryClueRemarkByClueIdForDetail(String clueId) {
        return clueRemarkMapper.selectClueRemarkByClueIdForDetail(clueId);
    }

    @Override
    public int saveClueRemark(ClueRemark clueRemark) {
        return clueRemarkMapper.insertClueRemark(clueRemark);
    }

    @Override
    public int deleteClueRemarkById(String id) {
        return clueRemarkMapper.deleteClueRemarkById(id);
    }

    @Override
    public int editClueRemark(ClueRemark clueRemark) {
        return clueRemarkMapper.updateClueRemark(clueRemark);
    }
}
