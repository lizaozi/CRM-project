package edu.zhku.crm.workbench.service;

import edu.zhku.crm.workbench.domain.Clue;

import java.util.List;
import java.util.Map;

/**
 * @author lzw
 * @date 2022/4/30
 * @description
 */
public interface ClueService {
    int saveCreateClue(Clue clue);

    List<Clue> queryAllClueByConditionForPage(Map<String,Object> map);

    int queryCountOfClueByCondition(Map<String,Object> map);

    void deleteClueByIds(String[] ids);

    Clue queryClueById(String id);

    int editClueById(Clue clue);

    Clue queryClueByIdForDetail(String id);

    void saveConvertClue(Map<String,Object> map);
}
