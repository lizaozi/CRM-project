package edu.zhku.crm.workbench.service;

import edu.zhku.crm.workbench.domain.ClueRemark;

import java.util.List;

/**
 * @author lzw
 * @date 2022/5/2
 * @description
 */
public interface ClueRemarkService {
    List<ClueRemark> queryClueRemarkByClueIdForDetail(String clueId);

    int saveClueRemark(ClueRemark clueRemark);

    int deleteClueRemarkById(String id);

    int editClueRemark(ClueRemark clueRemark);
}
