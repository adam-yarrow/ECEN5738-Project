function [Q, R] = buildQR_ARE(const)
    clf = const.clf;
    Q = clf.Qgain^2 * diag(clf.stateWeights.^2 ./ clf.stateMaxes.^2);
    Q = Q(clf.errorStateIdx, clf.errorStateIdx);
    R = clf.Rgain^2 * diag(clf.controlWeights.^2 ./ clf.controlMaxes.^2);
end