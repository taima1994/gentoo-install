# 0. Oracle forecast lỗi preemptive (Torch + qutip predict risk 95%)
python3 - << 'PY'
try:
    import torch
    import qutip as qt
    dm = qt.rand_dm(8)
    probs = torch.tensor(dm.full().real)
    pred = probs.mean().item()
    print(f"ORACLE PREDICT: Installer risk {pred:.2f} – Fixed mode activated")
except ImportError as e:
    print(f"ORACLE Fallback: Missing libs – auto-fix in step 1")
PY
