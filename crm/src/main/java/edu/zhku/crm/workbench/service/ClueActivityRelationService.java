package edu.zhku.crm.workbench.service;

import edu.zhku.crm.workbench.domain.ClueActivityRelation;

import java.util.List;

/**
 * @author lzw
 * @date 2022/5/2
 * @description
 */
public interface ClueActivityRelationService {
    int saveActivityRelationByList(List<ClueActivityRelation> list);

    int deleteClueActivityRelationByClueIdActivityId(ClueActivityRelation relation);
}
