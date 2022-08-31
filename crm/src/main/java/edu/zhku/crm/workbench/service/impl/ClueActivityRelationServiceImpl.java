package edu.zhku.crm.workbench.service.impl;

import edu.zhku.crm.workbench.domain.ClueActivityRelation;
import edu.zhku.crm.workbench.mapper.ClueActivityRelationMapper;
import edu.zhku.crm.workbench.service.ClueActivityRelationService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

/**
 * @author lzw
 * @date 2022/5/2
 * @description
 */
@Service("clueActivityRelationService")
public class ClueActivityRelationServiceImpl implements ClueActivityRelationService {

    @Resource
    private ClueActivityRelationMapper clueActivityRelationMapper;

    @Override
    public int saveActivityRelationByList(List<ClueActivityRelation> list) {
        return clueActivityRelationMapper.insertClueActivityRelationByList(list);
    }

    @Override
    public int deleteClueActivityRelationByClueIdActivityId(ClueActivityRelation relation) {
        return clueActivityRelationMapper.deleteClueActivityRelationByClueIdActivityId(relation);
    }
}
