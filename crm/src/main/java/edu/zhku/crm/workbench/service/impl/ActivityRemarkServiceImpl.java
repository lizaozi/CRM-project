package edu.zhku.crm.workbench.service.impl;

import edu.zhku.crm.workbench.domain.ActivityRemark;
import edu.zhku.crm.workbench.mapper.ActivityRemarkMapper;
import edu.zhku.crm.workbench.service.ActivityRemarkService;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import java.util.List;

/**
 * @author lzw
 * @date 2022/4/28
 * @description
 */
@Service("activityRemarkService")
public class ActivityRemarkServiceImpl implements ActivityRemarkService {

    @Resource
    private ActivityRemarkMapper activityRemarkMapper;

    @Override
    public List<ActivityRemark> queryActivityRemarkByActivityIdForDetail(String activityId) {
        return activityRemarkMapper.selectActivityRemarkByActivityIdForDetail(activityId);
    }

    @Override
    public int saveCreateActivityRemark(ActivityRemark remark) {
        return activityRemarkMapper.insertActivityRemark(remark);
    }

    @Override
    public int deleteActivityRemarkById(String id) {
        return activityRemarkMapper.deleteActivityRemarkById(id);
    }

    @Override
    public int saveEditActivityRemark(ActivityRemark remark) {
        return activityRemarkMapper.updateActivityRemark(remark);
    }
}
