function [Q, R] = buildQR_ARE(const)
    clf = const.clf;
    Q = diag(clf.stateWeights.^2 ./ clf.stateMaxes.^2);
    Q = Q(clf.errorStateIdx, clf.errorStateIdx);
    R = clf.QR_RelWeight * diag(clf.controlWeights.^2 ./ clf.controlMaxes.^2);
end